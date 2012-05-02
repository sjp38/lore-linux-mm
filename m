Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 1402F6B0081
	for <linux-mm@kvack.org>; Wed,  2 May 2012 02:51:52 -0400 (EDT)
Received: by yhr47 with SMTP id 47so443267yhr.14
        for <linux-mm@kvack.org>; Tue, 01 May 2012 23:51:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FA08BDB.1070009@gmail.com>
References: <20120418083208.GA24904@lizard>
	<20120418083523.GB31556@lizard>
	<alpine.LFD.2.02.1204182259580.11868@tux.localdomain>
	<20120418224629.GA22150@lizard>
	<alpine.LFD.2.02.1204190841290.1704@tux.localdomain>
	<20120419162923.GA26630@lizard>
	<20120501131806.GA22249@lizard>
	<4FA04FD5.6010900@redhat.com>
	<20120502002026.GA3334@lizard>
	<4FA08BDB.1070009@gmail.com>
Date: Wed, 2 May 2012 09:51:51 +0300
Message-ID: <CAOJsxLHJJD5en3gpbm=DY7gtLwu1cd_H2VtK979jDO6+XaAuvA@mail.gmail.com>
Subject: Re: [PATCH v4] vmevent: Implement greater-than attribute state and
 one-shot mode
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, Rik van Riel <riel@redhat.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, Glauber Costa <glommer@parallels.com>, kamezawa.hiroyu@jp.fujitsu.com, Suleiman Souhlal <suleiman@google.com>

On Wed, May 2, 2012 at 4:20 AM, KOSAKI Motohiro
<kosaki.motohiro@gmail.com> wrote:
> But, if it doesn't work desktop/server area, it shouldn't be merged.
> We have to consider the best design before kernel inclusion. They cann't
> be separeted to discuss.

Yes, completely agreed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
