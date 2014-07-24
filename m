Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5783B6B006C
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 15:21:56 -0400 (EDT)
Received: by mail-lb0-f170.google.com with SMTP id w7so2698366lbi.29
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 12:21:55 -0700 (PDT)
Received: from mail-lb0-x22f.google.com (mail-lb0-x22f.google.com [2a00:1450:4010:c04::22f])
        by mx.google.com with ESMTPS id qp9si28849097lbb.61.2014.07.24.12.21.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Jul 2014 12:21:54 -0700 (PDT)
Received: by mail-lb0-f175.google.com with SMTP id 10so2598876lbg.20
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 12:21:54 -0700 (PDT)
Date: Thu, 24 Jul 2014 23:21:52 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [rfc 1/4] mm: Introduce may_adjust_brk helper
Message-ID: <20140724192152.GC17876@moon>
References: <20140724164657.452106845@openvz.org>
 <20140724165047.437075575@openvz.org>
 <CAGXu5j+QHcrYjT8F9TZLA8YbJzZed28scp2y22QNO20sRF8Ndw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5j+QHcrYjT8F9TZLA8YbJzZed28scp2y22QNO20sRF8Ndw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andrew Vagin <avagin@openvz.org>, "Eric W. Biederman" <ebiederm@xmission.com>, "H. Peter Anvin" <hpa@zytor.com>, Serge Hallyn <serge.hallyn@canonical.com>, Pavel Emelyanov <xemul@parallels.com>, Vasiliy Kulikov <segoon@openwall.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michael Kerrisk-manpages <mtk.manpages@gmail.com>, Julien Tinnes <jln@google.com>

On Thu, Jul 24, 2014 at 12:18:56PM -0700, Kees Cook wrote:
> >
> > +static inline int may_adjust_brk(unsigned long rlim,
> > +                                unsigned long new_brk,
> > +                                unsigned long start_brk,
> > +                                unsigned long end_data,
> > +                                unsigned long start_data)
> > +{
> > +       if (rlim < RLIMIT_DATA) {
> 
> Won't rlim always be the value from a call to rlimit(RLIMIT_DATA)? Is
> there a good reason to not just put the rlimit() call in
> may_adjust_brk()? This would actually be an optimization in the
> prctl_set_mm case, since now it calls rlimit() unconditionally, but
> doesn't need to.

Nope, we use it for rlimit(RLIMIT_STACK) when checking for
@start_stack member.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
