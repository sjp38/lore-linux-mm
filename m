Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 127E16B0081
	for <linux-mm@kvack.org>; Mon, 21 May 2012 04:43:20 -0400 (EDT)
Message-ID: <4FB9FFA1.3040600@parallels.com>
Date: Mon, 21 May 2012 12:41:05 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] Common code 01/12] [slob] define page struct fields used
 in mm_types.h
References: <20120518161906.207356777@linux.com> <20120518161927.549888128@linux.com>
In-Reply-To: <20120518161927.549888128@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>, Alex Shi <alex.shi@intel.com>

On 05/18/2012 08:19 PM, Christoph Lameter wrote:
> Define the fields used by slob in mm_types.h and use struct page instead
> of struct slob_page in slob. This cleans up numerous of typecasts in slob.c and
> makes readers aware of slob's use of page struct fields.
>
> [Also cleans up some bitrot in slob.c. The page struct field layout
> in slob.c is an old layout and does not match the one in mm_types.h]
>
> Signed-off-by: Christoph Lameter<cl@linux.com>

Reviewed by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
