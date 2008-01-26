Received: by py-out-1112.google.com with SMTP id f47so1149503pye.20
        for <linux-mm@kvack.org>; Sat, 26 Jan 2008 09:10:25 -0800 (PST)
Message-ID: <2f11576a0801260910m762cceaau32a7fae3875824a5@mail.gmail.com>
Date: Sun, 27 Jan 2008 02:10:25 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/2] Relax restrictions on setting CONFIG_NUMA on x86
In-Reply-To: <2f11576a0801260610m29f4e7ecle9828d8bbaa462cd@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie>
	 <20080121093702.8FC2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080123105810.F295.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080123102332.GB21455@csn.ul.ie>
	 <2f11576a0801260610m29f4e7ecle9828d8bbaa462cd@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org, kosaki.motohiro@gmail.com
List-ID: <linux-mm.kvack.org>

> 1. if sparce_mem on, build failture

after fix compile error, no panic and bad-page happened both highmem
off and 64G.
I guess discontigmem numa is premature yet ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
