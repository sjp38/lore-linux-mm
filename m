Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id l9PKACUF011800
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 13:10:12 -0700
Received: from nf-out-0910.google.com (nfhf5.prod.google.com [10.48.233.5])
	by zps75.corp.google.com with ESMTP id l9PK9asg013388
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 13:10:11 -0700
Received: by nf-out-0910.google.com with SMTP id f5so473391nfh
        for <linux-mm@kvack.org>; Thu, 25 Oct 2007 13:10:11 -0700 (PDT)
Message-ID: <d43160c70710251310o7113f1cbo68872365c193e94c@mail.gmail.com>
Date: Thu, 25 Oct 2007 16:10:11 -0400
From: "Ross Biro" <rossb@google.com>
Subject: Re: RFC/POC Make Page Tables Relocatable
In-Reply-To: <1193342419.24087.71.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <d43160c70710250816l44044f31y6dd20766d1f2840b@mail.gmail.com>
	 <1193330774.4039.136.camel@localhost>
	 <d43160c70710251040u23feeaf9l16fafc2685b2ce52@mail.gmail.com>
	 <1193335725.24087.19.camel@localhost>
	 <d43160c70710251144t172cfd1exef99e0d53fb9be73@mail.gmail.com>
	 <1193340182.24087.54.camel@localhost>
	 <d43160c70710251253j2f4e640uc0ccc0432738f55c@mail.gmail.com>
	 <1193342419.24087.71.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, Mel Gorman <MELGOR@ie.ibm.com>
List-ID: <linux-mm.kvack.org>

On 10/25/07, Dave Hansen <haveblue@us.ibm.com> wrote:
> How would it get freed?
>

The process exists or ummaps the range of memory.  The relocation code
is likely called on a different cpu in the node and currently has no
way to pin the data in memory.  Perhaps finding a way to pin the page
would help the other locking issues, so it might solve lots of
problems.

    Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
