Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BD7666B0272
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 12:13:49 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id p5-v6so781438edh.16
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 09:13:49 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s19-v6si1320837edc.383.2018.07.17.09.13.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 09:13:48 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6HG9Hoq164816
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 12:13:47 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2k9j7xmmwv-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 12:13:46 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Tue, 17 Jul 2018 17:13:45 +0100
Date: Tue, 17 Jul 2018 09:13:32 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v13 19/24] selftests/vm: associate key on a mapped page
 and detect access violation
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
 <1528937115-10132-20-git-send-email-linuxram@us.ibm.com>
 <048b1de9-85f8-22ff-a31a-b06a382769bb@intel.com>
MIME-Version: 1.0
In-Reply-To: <048b1de9-85f8-22ff-a31a-b06a382769bb@intel.com>
Message-Id: <20180717161332.GH5790@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

On Wed, Jun 20, 2018 at 08:16:44AM -0700, Dave Hansen wrote:
> On 06/13/2018 05:45 PM, Ram Pai wrote:
> > +void test_read_of_access_disabled_region_with_page_already_mapped(int *ptr,
> > +		u16 pkey)
> > +{
> > +	int ptr_contents;
> > +
> > +	dprintf1("disabling access to PKEY[%02d], doing read @ %p\n",
> > +				pkey, ptr);
> > +	ptr_contents = read_ptr(ptr);
> > +	dprintf1("reading ptr before disabling the read : %d\n",
> > +			ptr_contents);
> > +	read_pkey_reg();
> > +	pkey_access_deny(pkey);
> > +	ptr_contents = read_ptr(ptr);
> > +	dprintf1("*ptr: %d\n", ptr_contents);
> > +	expected_pkey_fault(pkey);
> > +}
> 
> Looks fine to me.  I'm a bit surprised we didn't do this already, which
> is a good thing for this patch.
> 
> FWIW, if you took patches like this and put them first, you could
> probably get it merged now.  Yes, I know it would mean redoing some of
> the later code move and rename ones.

I have incorporated almost all of your comments. But there are some
comments that take some effort to implement. Shall we get the patches
merged in the current form?  This code has been sitting out for a while.

In the current form its tested and works on powerpc and on x86, and
incorporates about 95% of your suggestions. The rest I will take care
as we go.

-- 
Ram Pai
