Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 261A56B005D
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 09:28:54 -0400 (EDT)
Received: by yhjj52 with SMTP id j52so6444884yhj.8
        for <linux-mm@kvack.org>; Tue, 03 Jul 2012 06:28:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120703123119.GA5103@phenom.ffwll.local>
References: <20120620113252.GE4011@suse.de> <20120629111932.GA14154@suse.de>
 <20120629112505.GF14154@suse.de> <20120701235458.GM19223@dastard>
 <20120702063226.GA32151@infradead.org> <20120702143215.GS14154@suse.de>
 <20120702193516.GX14154@suse.de> <20120703001928.GV19223@dastard>
 <20120703105951.GB14154@suse.de> <20120703123119.GA5103@phenom.ffwll.local>
From: Eugeni Dodonov <eugeni@dodonov.net>
Date: Tue, 3 Jul 2012 10:28:12 -0300
Message-ID: <CAC7LmntOQoDOchQRc94=YB08WvH8k+uOOFPTp9v=uaigXP8ONw@mail.gmail.com>
Subject: Re: [MMTests] IO metadata on XFS
Content-Type: multipart/alternative; boundary=20cf303f6a1645b38304c3ece5f3
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, dri-devel@lists.freedesktop.org, Keith Packard <keithp@keithp.com>, Eugeni Dodonov <eugeni.dodonov@intel.com>, Chris Wilson <chris@chris-wilson.co.uk>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>

--20cf303f6a1645b38304c3ece5f3
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Jul 3, 2012 at 9:31 AM, Daniel Vetter <daniel@ffwll.ch> wrote:

> Well, presuming I understand things correctly the cpu die only goes into
> the lowest sleep state (which iirc switches off l3 caches and
> interconnects) when both the cpu and gpu are in the lowest sleep state.
> rc6 is that deep-sleep state for the gpu, so without that enabled your
> system won't go into these deep-sleep states.
>
> I guess the slight changes in wakeup latency, power consumption (cuts
> about 10W on an idle desktop snb with resulting big effect on what turbo
> boost can sustain for short amounts of time) and all the follow-on effects
> are good enough to massively change timing-critical things.
>

The sad side effect is that the software has very little control over the
RC6 entry and exit, the hardware enters and leaves RC6 state on its own
when it detects that the GPU is idle beyond a threshold. Chances are that
if you are not running any GPU workload, the GPU simple enters RC6 state
and stays there.

It is possible to observe the current state and also time spent in rc6 by
looking at the /sys/kernel/debug/dri/0/i915_drpc_info file.

One other effect of RC6 is that it also allows CPU to go into higher turbo
modes as it has more watts to spend while GPU is idle, perhaps this is what
causes the issue here?

-- 
Eugeni Dodonov
<http://eugeni.dodonov.net/>

--20cf303f6a1645b38304c3ece5f3
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div class=3D"gmail_quote">On Tue, Jul 3, 2012 at 9:31 AM, Daniel Vetter <s=
pan dir=3D"ltr">&lt;<a href=3D"mailto:daniel@ffwll.ch" target=3D"_blank">da=
niel@ffwll.ch</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">

<div class=3D"HOEnZb"><div class=3D"h5">Well, presuming I understand things=
 correctly the cpu die only goes into</div></div>
the lowest sleep state (which iirc switches off l3 caches and<br>
interconnects) when both the cpu and gpu are in the lowest sleep state.<br>
rc6 is that deep-sleep state for the gpu, so without that enabled your<br>
system won&#39;t go into these deep-sleep states.<br>
<br>
I guess the slight changes in wakeup latency, power consumption (cuts<br>
about 10W on an idle desktop snb with resulting big effect on what turbo<br=
>
boost can sustain for short amounts of time) and all the follow-on effects<=
br>
are good enough to massively change timing-critical things.<br></blockquote=
><div><br></div><div>The sad side effect is that the software has very litt=
le control over the RC6 entry and exit, the hardware enters and leaves RC6 =
state on its own when it detects that the GPU is idle beyond a threshold.=
=A0Chances are that if you are not running any GPU workload, the GPU simple=
 enters RC6 state and stays there.</div>

<div><br></div><div>It is possible to observe the current state and also ti=
me spent in rc6 by looking at the=A0/sys/kernel/debug/dri/0/i915_drpc_info =
file.</div><div><br></div><div>One other effect of RC6 is that it also allo=
ws CPU to go into higher turbo modes as it has more watts to spend while GP=
U is idle, perhaps this is what causes the issue here?</div>

<div><br></div></div>-- <br>Eugeni Dodonov<a href=3D"http://eugeni.dodonov.=
net/" target=3D"_blank"><br></a><br>

--20cf303f6a1645b38304c3ece5f3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
