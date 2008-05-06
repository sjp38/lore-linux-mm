Received: by qb-out-0506.google.com with SMTP id d11so240026qbd.0
        for <linux-mm@kvack.org>; Tue, 06 May 2008 06:02:39 -0700 (PDT)
Message-ID: <2f11576a0805060602gf4cf0f9t85391939146efccf@mail.gmail.com>
Date: Tue, 6 May 2008 22:02:38 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm/cgroup.c add error check
In-Reply-To: <87wsm7bo1n.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080506195216.4A6D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <87wsm7bo1n.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

>  > on heavy workload, call_usermodehelper() may failure
>  > because it use kzmalloc(GFP_ATOMIC).
>
>  Better just fix it to not use GFP_ATOMIC in the first place.

Ah, makes sense.
I'll try toi create that patch.

but if GFP_KERNEL is used, We still need error check, IMHO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
