Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id B3E056B0044
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 18:24:36 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so3582714pad.14
        for <linux-mm@kvack.org>; Fri, 12 Oct 2012 15:24:36 -0700 (PDT)
Date: Fri, 12 Oct 2012 15:21:42 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [PATCH 2/3] vmevent: Factor vmevent_match_attr() out of
 vmevent_match()
Message-ID: <20121012222141.GA15629@lizard>
References: <20121004102013.GA23284@lizard>
 <1349346078-24874-2-git-send-email-anton.vorontsov@linaro.org>
 <CAOJsxLFW3WbBDdFhuJDwUxvGVfsy_Tg8SpR4pxTWAcfQ+LG0UQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAOJsxLFW3WbBDdFhuJDwUxvGVfsy_Tg8SpR4pxTWAcfQ+LG0UQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org

On Fri, Oct 12, 2012 at 03:37:43PM +0300, Pekka Enberg wrote:
[...]
> > +static bool vmevent_match_attr(struct vmevent_attr *attr, u64 value)
> > +{
> > +       u32 state = attr->state;
> > +       bool attr_lt = state & VMEVENT_ATTR_STATE_VALUE_LT;
> > +       bool attr_gt = state & VMEVENT_ATTR_STATE_VALUE_GT;
> > +       bool attr_eq = state & VMEVENT_ATTR_STATE_VALUE_EQ;
> > +       bool edge = state & VMEVENT_ATTR_STATE_EDGE_TRIGGER;
> > +       u32 was_lt_mask = VMEVENT_ATTR_STATE_VALUE_WAS_LT;
> > +       u32 was_gt_mask = VMEVENT_ATTR_STATE_VALUE_WAS_GT;
> > +       bool lt = value < attr->value;
> > +       bool gt = value > attr->value;
> > +       bool eq = value == attr->value;
> > +       bool was_lt = state & was_lt_mask;
> > +       bool was_gt = state & was_gt_mask;
> 
> [snip]
> 
> So I merged this patch but vmevent_match_attr() is still too ugly for
> words. It really could use some serious cleanups.

Thanks a lot for merging these cleanups!

Yes, the patch wasn't meant to simplify the matching logic, but just to
let us use the function in other places.

I once started converting the function into table-based approach, but the
code started growing, and I abandoned the idea for now. I might resume the
work just for the fun of it, but the code will be larger than this ad-hoc
function, althouh surely it will be more generic and understandable.

But let's solve primary problems with the vmevent first. :-)

Thanks,
Anton.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
