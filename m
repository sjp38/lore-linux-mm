Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 0A1C46B004D
	for <linux-mm@kvack.org>; Tue,  1 May 2012 23:52:00 -0400 (EDT)
Received: by yhr47 with SMTP id 47so283918yhr.14
        for <linux-mm@kvack.org>; Tue, 01 May 2012 20:52:00 -0700 (PDT)
Date: Tue, 1 May 2012 20:50:35 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [PATCH v4] vmevent: Implement greater-than attribute state and
 one-shot mode
Message-ID: <20120502035035.GA18787@lizard>
References: <20120418083523.GB31556@lizard>
 <alpine.LFD.2.02.1204182259580.11868@tux.localdomain>
 <20120418224629.GA22150@lizard>
 <alpine.LFD.2.02.1204190841290.1704@tux.localdomain>
 <20120419162923.GA26630@lizard>
 <20120501131806.GA22249@lizard>
 <4FA04FD5.6010900@redhat.com>
 <20120502002026.GA3334@lizard>
 <4FA08BDB.1070009@gmail.com>
 <20120502033136.GA14740@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20120502033136.GA14740@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, Glauber Costa <glommer@parallels.com>, kamezawa.hiroyu@jp.fujitsu.com, Suleiman Souhlal <suleiman@google.com>

On Tue, May 01, 2012 at 08:31:36PM -0700, Anton Vorontsov wrote:
[...]
> p.s. I'm not the vmevents author, plus I use both memcg and
> vmevents. That makes me think that I'm pretty unbiased here. ;-)

...though, that doesn't mean I'm right, of course. :-)

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
