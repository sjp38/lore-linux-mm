Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id NAA13838
	for <linux-mm@kvack.org>; Thu, 27 Feb 2003 13:47:28 -0800 (PST)
Date: Thu, 27 Feb 2003 13:44:03 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Rising io_load results Re: 2.5.63-mm1
Message-Id: <20030227134403.776bf2e3.akpm@digeo.com>
In-Reply-To: <200302280822.09409.kernel@kolivas.org>
References: <20030227025900.1205425a.akpm@digeo.com>
	<200302280822.09409.kernel@kolivas.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Con Kolivas <kernel@kolivas.org> wrote:
>
> 
> This started some time around 2.5.62-mm3 with the io_load results on contest 
> benchmarking (http://contest.kolivas.org) rising with each run.
> ...
> Mapped:       4294923652 kB

Well that's gotta hurt.  This metric is used in making writeback decisions. 
Probably the objrmap patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
