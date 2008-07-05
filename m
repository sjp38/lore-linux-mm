Message-ID: <486F112E.5090001@garzik.org>
Date: Sat, 05 Jul 2008 02:14:06 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>	 <20080703205548.D6E5.KOSAKI.MOTOHIRO@jp.fujitsu.com>	 <486CC440.9030909@garzik.org>	 <Pine.LNX.4.64.0807031353030.11033@blonde.site>	 <s5hmykxc3ja.wl%tiwai@suse.de>	 <1215177471.10393.753.camel@pmac.infradead.org>	 <s5hej69lqzk.wl%tiwai@suse.de>  <486E28BB.1030205@garzik.org>	 <1215179126.10393.771.camel@pmac.infradead.org>	 <486E2F68.2000707@garzik.org> <1215180802.10393.783.camel@pmac.infradead.org>
In-Reply-To: <1215180802.10393.783.camel@pmac.infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Takashi Iwai <tiwai@suse.de>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David Woodhouse wrote:
> I'm working on making the required firmware get installed as part of
> 'make modules_install'.

Great!  That will definitely reduce silent regressions due to build 
process changes.

	Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
