Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3F26B0270
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 12:09:26 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i26-v6so787435edr.4
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 09:09:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u25-v6si1381723eds.287.2018.07.17.09.09.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 09:09:25 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6HG9GHe164799
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 12:09:24 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2k9j7xmf5n-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 12:09:23 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Tue, 17 Jul 2018 17:09:21 +0100
Date: Tue, 17 Jul 2018 09:09:10 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v13 22/24] selftests/vm: testcases must restore
 pkey-permissions
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
 <1528937115-10132-23-git-send-email-linuxram@us.ibm.com>
 <e4e63ab2-2830-9ade-3e5f-6d0f61efbcb6@intel.com>
MIME-Version: 1.0
In-Reply-To: <e4e63ab2-2830-9ade-3e5f-6d0f61efbcb6@intel.com>
Message-Id: <20180717160910.GG5790@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

On Wed, Jun 20, 2018 at 08:20:22AM -0700, Dave Hansen wrote:
> On 06/13/2018 05:45 PM, Ram Pai wrote:
> > Generally the signal handler restores the state of the pkey register
> > before returning. However there are times when the read/write operation
> > can legitamely fail without invoking the signal handler.  Eg: A
> > sys_read() operaton to a write-protected page should be disallowed.  In
> > such a case the state of the pkey register is not restored to its
> > original state.  The test case is responsible for restoring the key
> > register state to its original value.
> 
> Seems fragile.  Can't we just do this in common code?  We could just
> loop through and restore the default permissions.  That seems much more
> resistant to a bad test case.

Yes. done. fixed it the way you suggested in the new version.


-- 
Ram Pai
