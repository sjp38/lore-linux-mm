Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4708A6B0253
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 02:49:26 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id x79so42430634lff.2
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 23:49:26 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id n8si7267344lfi.235.2016.10.12.23.49.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 23:49:24 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id x23so5227572lfi.1
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 23:49:24 -0700 (PDT)
Subject: Re: [PATCH v3 0/1] man/set_mempolicy.2,mbind.2: add MPOL_LOCAL NUMA
 memory policy documentation
References: <alpine.DEB.2.20.1610100854001.27158@east.gentwo.org>
 <20161010162310.2463-1-kwapulinski.piotr@gmail.com>
 <4d816fee-4690-2ed7-7faa-c437e67cfbf5@gmail.com> <20161012155309.GA2706@home>
 <alpine.DEB.2.20.1610121455040.11069@east.gentwo.org>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <898fa754-6dd1-8ba6-fa69-edda33ab0429@gmail.com>
Date: Thu, 13 Oct 2016 08:48:48 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1610121455040.11069@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Cc: mtk.manpages@gmail.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, rientjes@google.com, mhocko@kernel.org, mgorman@techsingularity.net, liangchen.linux@gmail.com, nzimmer@sgi.com, a.p.zijlstra@chello.nl, riel@redhat.com, lee.schermerhorn@hp.com, jmarchan@redhat.com, joe@perches.com, corbet@lwn.net, iamyooon@gmail.com, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-man@vger.kernel.org, akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org

On 10/12/2016 09:55 PM, Christoph Lameter wrote:
> On Wed, 12 Oct 2016, Piotr Kwapulinski wrote:
> 
>> That's right. This could be "local allocation" or any other memory policy.
> 
> Correct.
> 

Thanks, Piotr and Christoph.

Cheers,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
