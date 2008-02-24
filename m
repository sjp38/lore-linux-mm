Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id m1O36lmj001459
	for <linux-mm@kvack.org>; Sun, 24 Feb 2008 03:06:48 GMT
Received: from py-out-1112.google.com (pyed37.prod.google.com [10.34.156.37])
	by zps35.corp.google.com with ESMTP id m1O36k1q014071
	for <linux-mm@kvack.org>; Sat, 23 Feb 2008 19:06:46 -0800
Received: by py-out-1112.google.com with SMTP id d37so1898888pye.29
        for <linux-mm@kvack.org>; Sat, 23 Feb 2008 19:06:46 -0800 (PST)
Message-ID: <6599ad830802231906k3ae0e30fvcda453d7afc4d907@mail.gmail.com>
Date: Sat, 23 Feb 2008 19:06:45 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH 2/2] ResCounter: Use read_uint in memory controller
In-Reply-To: <47C0DAD8.8050401@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080221203518.544461000@menage.corp.google.com>
	 <20080221205525.349180000@menage.corp.google.com>
	 <47BE4FB5.5040902@linux.vnet.ibm.com>
	 <6599ad830802230633i483c8dd1q5b541be1a92a5795@mail.gmail.com>
	 <20080223105933.e6884808.akpm@linux-foundation.org>
	 <47C0DAD8.8050401@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, xemul@openvz.org, balbir@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 23, 2008 at 6:47 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>  >> res_counter_read_u64() I'd also want to rename all the other
>  >> *read_uint functions/fields to *read_u64 too. Can I do that in a
>  >> separate patch?
>  >>
>  >
>  > Sounds sensible to me.
>  >
>
>  Sure, fair enough.
>

Actually, since multiple people were asking for this change I did the
search/replace and sent it out already (as a precursor of the other
patches in the series that I sent today).

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
