Received: by wa-out-1112.google.com with SMTP id m33so2013437wag
        for <linux-mm@kvack.org>; Tue, 10 Jul 2007 19:54:40 -0700 (PDT)
Message-ID: <b21f8390707101954s3ae69db8vc30287277941cb1f@mail.gmail.com>
Date: Wed, 11 Jul 2007 12:54:40 +1000
From: "Matthew Hawkins" <darthmdh@gmail.com>
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
In-Reply-To: <20070710181419.6d1b2f7e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <200707102015.44004.kernel@kolivas.org>
	 <b21f8390707101802o2d546477n2a18c1c3547c3d7a@mail.gmail.com>
	 <20070710181419.6d1b2f7e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Con Kolivas <kernel@kolivas.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 7/11/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Wed, 11 Jul 2007 11:02:56 +1000 "Matthew Hawkins" <darthmdh@gmail.com> wrote:

> Always interested.  Please provide us more details on your usage and
> testing of that code.  Amount of memory, workload, observed results,
> etc?

My usual workstation has 1Gb of ram & 2Gb of swap (single partition -
though in the past with multiple drives I would spread swap around the
less-used disks & fiddle with the priority).  Its acting as server for
my home network too (so it has squid, cups, bind, dhcpd, apache, mysql
& postgresql) but for the most part I'll have Listen playing music
while I switch between Flock &/or Firefox, Thunderbird, and
xvncviewer.  On the odd occasion I'll fire up some game (gewled,
actioncube, critical mass).  Compiling these days has been mostly
limited to kernels, I've been building mostly -ck and -cfs - keeping
up-to-date and also doing some odd things (like patching the non-SD
-ck stuff on top of CFS).  Mainly just to get swap prefetch, but also
not to lose skills since I'm out of the daily coding routine now.

Anyhow with swap prefetch, applications that may have been sitting
there idle for a while become responsive in the single-digit seconds
rather than double-digit or worse.  The same goes for a morning wakeup
(ie after nightly cron jobs throw things out) and also after doing
basically anything that wants memory, like benchmarking the various
kernels I'm messing with or doing some local DB work or coding a
memory leak into a web application running under apache ;)

-- 
Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
