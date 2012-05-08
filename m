Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 21F2B6B004D
	for <linux-mm@kvack.org>; Tue,  8 May 2012 05:19:58 -0400 (EDT)
Received: by yenm8 with SMTP id m8so7285485yen.14
        for <linux-mm@kvack.org>; Tue, 08 May 2012 02:19:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <84FF21A720B0874AA94B46D76DB98269045D63B3@008-AM1MPN1-003.mgdnok.nokia.com>
References: <20120501132409.GA22894@lizard>
	<20120501132620.GC24226@lizard>
	<4FA35A85.4070804@kernel.org>
	<20120504073810.GA25175@lizard>
	<CAOJsxLH_7mMMe+2DvUxBW1i5nbUfkbfRE3iEhLQV9F_MM7=eiw@mail.gmail.com>
	<CAHGf_=qcGfuG1g15SdE0SDxiuhCyVN025pQB+sQNuNba4Q4jcA@mail.gmail.com>
	<20120507121527.GA19526@lizard>
	<4FA82056.2070706@gmail.com>
	<CAOJsxLHQcDZSHJZg+zbptqmT9YY0VTkPd+gG_zgMzs+HaV_cyA@mail.gmail.com>
	<CAHGf_=q1nbu=3cnfJ4qXwmngMPB-539kg-DFN2FJGig8+dRaNw@mail.gmail.com>
	<CAOJsxLFAavdDbiLnYRwe+QiuEHSD62+Sz6LJTk+c3J9gnLVQ_w@mail.gmail.com>
	<CAHGf_=pSLfAue6AR5gi5RQ7xvgTxpZckA=Ja1fO1AkoO1o_DeA@mail.gmail.com>
	<CAOJsxLG1+zhOKgi2Rg1eSoXSCU8QGvHVED_EefOOLP-6JbMDkg@mail.gmail.com>
	<4FA8D046.7000808@gmail.com>
	<CAOJsxLGWtJy7q6ij_-tN8nVTr-OXpgdWVkXsOda8S9mJzo7n2w@mail.gmail.com>
	<84FF21A720B0874AA94B46D76DB98269045D63B3@008-AM1MPN1-003.mgdnok.nokia.com>
Date: Tue, 8 May 2012 12:19:57 +0300
Message-ID: <CAOJsxLEm2LfBB031-pU5Srhr+=DVDCmexZm_UczCzqQ2JmgoRw@mail.gmail.com>
Subject: Re: [PATCH 3/3] vmevent: Implement special low-memory attribute
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: kosaki.motohiro@gmail.com, anton.vorontsov@linaro.org, minchan@kernel.org, john.stultz@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Tue, May 8, 2012 at 12:15 PM,  <leonid.moiseichuk@nokia.com> wrote:
> I am tracking conversation with quite low understanding how it will be useful for
> practical needs because user-space developers in 80% cases needs to track
> simply dirty memory changes i.e. modified pages which cannot be dropped.

The point is to support those cases in such a way that works sanely
across different architectures and configurations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
