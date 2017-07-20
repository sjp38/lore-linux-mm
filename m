Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 025186B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 18:04:21 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id y3so26416541pgo.7
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 15:04:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m5si2090552pfb.609.2017.07.20.15.04.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jul 2017 15:04:20 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6KM4Ivn064519
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 18:04:19 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bu4mq8qnj-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 18:04:18 -0400
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Thu, 20 Jul 2017 16:04:10 -0600
Date: Thu, 20 Jul 2017 15:03:58 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [RFC v6 01/62] powerpc: Free up four 64K PTE bits in 4K backed
 HPTE pages
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
 <1500177424-13695-2-git-send-email-linuxram@us.ibm.com>
 <87d18vr6yw.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87d18vr6yw.fsf@skywalker.in.ibm.com>
Message-Id: <20170720220358.GH5487@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

On Thu, Jul 20, 2017 at 11:21:51AM +0530, Aneesh Kumar K.V wrote:
> 
> .....
> 
> >  	/*
> > @@ -116,8 +104,8 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
> >  		 * On hash insert failure we use old pte value and we don't
> >  		 * want slot information there if we have a insert failure.
> >  		 */
> > -		old_pte &= ~(H_PAGE_HASHPTE | H_PAGE_F_GIX | H_PAGE_F_SECOND);
> > -		new_pte &= ~(H_PAGE_HASHPTE | H_PAGE_F_GIX | H_PAGE_F_SECOND);
> > +		old_pte &= ~(H_PAGE_HASHPTE);
> > +		new_pte &= ~(H_PAGE_HASHPTE);
> >  		goto htab_insert_hpte;
> >  	}
> 
> With the current path order and above hunk we will breaks the bisect I guess. With the above, when
> we convert a 64k hpte to 4khpte, since this is the first patch, we
> should clear that H_PAGE_F_GIX and H_PAGE_F_SECOND. We still use them
> for 64k. I guess you should move this hunk to second patch.

true. it should move to the next patch. Will fix it.
RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
