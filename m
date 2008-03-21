Subject: Re: [PATCH] Add definitions of USHRT_MAX
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <1206064278.26345.108.camel@localhost>
References: <1206063614.14496.72.camel@ymzhang>
	 <1206064278.26345.108.camel@localhost>
Content-Type: text/plain; charset=utf-8
Date: Fri, 21 Mar 2008 10:08:21 +0800
Message-Id: <1206065301.14496.77.camel@ymzhang>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joe Perches <joe@perches.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-03-20 at 18:51 -0700, Joe Perches wrote:
> On Fri, 2008-03-21 at 09:40 +0800, Zhang, Yanmin wrote:
> > Add definitions of USHRT_MAX and others into kernel. ipc uses it and
> > slub implementation might also use it.
> > +#define USHRT_MAX	((u16)(~0U))
> > +#define SHRT_MAX	((s16)(USHRT_MAX>>1))
> > +#define SHRT_MIN	(-SHRT_MAX - 1)
> 
> Perhaps it's better to use the most common kernel types?
ipc uses USHRT_MAX in a couple of files. Should we keep it consistent?

If ipc wouldn't use it, I would prefer your idea.

> Perhaps U16_MAX, S16_MAX and S16_MIN?
> 
> Don't you need to cast SHRT_MIN/S16_MIN too?
> #define S16_MIN ((s16)(-SHRT_MAX - 1))
No. I simulate INT_MIN. I also tested it by defining a var and didn't get
compilation warning.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
