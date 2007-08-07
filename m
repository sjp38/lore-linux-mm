Date: Tue, 7 Aug 2007 20:35:02 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070807203502.66b9ebda@the-village.bc.nu>
In-Reply-To: <46B8C016.6090806@tmr.com>
References: <20070803123712.987126000@chello.nl>
	<alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org>
	<20070804063217.GA25069@elte.hu>
	<20070804070737.GA940@elte.hu>
	<20070804103347.GA1956@elte.hu>
	<alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>
	<20070804163733.GA31001@elte.hu>
	<alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org>
	<46B4C0A8.1000902@garzik.org>
	<20070804191205.GA24723@lazybastard.org>
	<20070804192130.GA25346@elte.hu>
	<20070804211156.5f600d80@the-village.bc.nu>
	<46B4E161.9080100@garzik.org>
	<46B8C016.6090806@tmr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Davidsen <davidsen@tmr.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> However, relatime has the POSIX behavior without the overhead. Therefore 

No. relatime has approximately SuS behaviour. Its not the same as
"correct" behaviour.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
