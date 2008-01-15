Message-ID: <478CAB25.30300@grupopie.com>
Date: Tue, 15 Jan 2008 12:46:29 +0000
From: Paulo Marques <pmarques@grupopie.com>
MIME-Version: 1.0
Subject: Re: [RFC] mmaped copy too slow?
References: <20080115100450.1180.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080115100450.1180.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> Hi
> 
> at one point, I found the large file copy speed was different depending on
> the copy method.
> 
> I compared below method
>  - read(2) and write(2).
>  - mmap(2) x2 and memcpy.
>  - mmap(2) and write(2).
> 
> in addition, effect of fadvice(2) and madvice(2) is checked.
> 
> to a strange thing, 
>    - most faster method is read + write + fadvice.
>    - worst method is mmap + memcpy.

One thing you could also try is to pass MAP_POPULATE to mmap so that the 
page tables are filled in at the time of the mmap, avoiding a lot of 
page faults later.

Just my 2 cents,

-- 
Paulo Marques - www.grupopie.com

"All I ask is a chance to prove that money can't make me happy."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
