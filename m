Received: by po-out-1718.google.com with SMTP id y22so178912pof.1
        for <linux-mm@kvack.org>; Tue, 06 May 2008 13:19:46 -0700 (PDT)
Message-ID: <2f11576a0805061319w581f69d4ye593416db6a9e80a@mail.gmail.com>
Date: Wed, 7 May 2008 05:19:45 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm/cgroup.c add error check
In-Reply-To: <4820A431.3000600@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080506195216.4A6D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <87wsm7bo1n.fsf@basil.nowhere.org>
	 <2f11576a0805060602gf4cf0f9t85391939146efccf@mail.gmail.com>
	 <4820A431.3000600@firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

>  > but if GFP_KERNEL is used, We still need error check, IMHO.
>
>  Yes, but no retry (or if you're sure you cannot fail use __GFP_NOFAIL
>  too, but that is nasty because it has some risk of deadlock under severe
>  oom conditions)

in general coding style, you are right.

but not down-to-earth idea in that case.
call_usermodehelper() is just wrapper of fork-exec.

I don't hope change largely exec() code patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
