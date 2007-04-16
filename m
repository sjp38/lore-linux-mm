Message-ID: <46230A3A.8060907@zachcarter.com>
Date: Sun, 15 Apr 2007 22:31:38 -0700
From: Zach Carter <linux@zachcarter.com>
MIME-Version: 1.0
Subject: Re: BUG:  Bad page state errors during kernel make
References: <4622EDD3.9080103@zachcarter.com> <20070416035603.GD21217@redhat.com>
In-Reply-To: <20070416035603.GD21217@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Jones <davej@redhat.com>, Zach Carter <linux@zachcarter.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dave Jones wrote:
> On Sun, Apr 15, 2007 at 08:30:27PM -0700, Zach Carter wrote:
>  > list_del corruption. prev->next should be c21a4628, but was e21a4628
> 
> 'c' became 'e' in that last address. A single bit flipped.
> Given you've had this for some time, this smells like a hardware problem.
> memtest86+ will probably show up something.

Hum.   I forgot to mention in my report that I had already run thru 10 clean passes with memtest86+

Do you think there might be other bad hw, or another explanation?

-Zach

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
