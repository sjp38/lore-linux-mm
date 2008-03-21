Date: Fri, 21 Mar 2008 03:12:49 +0100 (CET)
From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH] Add definitions of USHRT_MAX
In-Reply-To: <1206064278.26345.108.camel@localhost>
Message-ID: <alpine.LNX.1.00.0803210312400.10642@fbirervta.pbzchgretzou.qr>
References: <1206063614.14496.72.camel@ymzhang> <1206064278.26345.108.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joe Perches <joe@perches.com>
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mar 20 2008 18:51, Joe Perches wrote:
> On Fri, 2008-03-21 at 09:40 +0800, Zhang, Yanmin wrote:
>> Add definitions of USHRT_MAX and others into kernel. ipc uses it and
>> slub implementation might also use it.
>> +#define USHRT_MAX	((u16)(~0U))
>> +#define SHRT_MAX	((s16)(USHRT_MAX>>1))
>> +#define SHRT_MIN	(-SHRT_MAX - 1)
>
> Perhaps it's better to use the most common kernel types?
> Perhaps U16_MAX, S16_MAX and S16_MIN?
>
> Don't you need to cast SHRT_MIN/S16_MIN too?
> #define S16_MIN ((s16)(-SHRT_MAX - 1))

SHRT_MAX is already s16.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
