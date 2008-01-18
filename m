Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id m0I9Q8lL019065
	for <linux-mm@kvack.org>; Fri, 18 Jan 2008 09:26:09 GMT
Received: from wa-out-1112.google.com (wahj4.prod.google.com [10.114.236.4])
	by zps77.corp.google.com with ESMTP id m0I9Q7vD018186
	for <linux-mm@kvack.org>; Fri, 18 Jan 2008 01:26:08 -0800
Received: by wa-out-1112.google.com with SMTP id j4so1911765wah.21
        for <linux-mm@kvack.org>; Fri, 18 Jan 2008 01:26:07 -0800 (PST)
Message-ID: <532480950801180126q3088e47dx1ac07dbd8390ca71@mail.gmail.com>
Date: Fri, 18 Jan 2008 01:26:07 -0800
From: "Michael Rubin" <mrubin@google.com>
Subject: Re: [patch] Converting writeback linked lists to a tree based data structure
In-Reply-To: <20080118085407.GV155259@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080115080921.70E3810653@localhost> <400562938.07583@ustc.edu.cn>
	 <532480950801171307q4b540ewa3acb6bfbea5dbc8@mail.gmail.com>
	 <20080118050107.GS155259@sgi.com>
	 <532480950801172138x44e06780w2b15464845b626fc@mail.gmail.com>
	 <20080118085407.GV155259@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: Fengguang Wu <wfg@mail.ustc.edu.cn>, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Jan 18, 2008 12:54 AM, David Chinner <dgc@sgi.com> wrote:
> At this point, I'd say it is best to leave it to the filesystem and
> the elevator to do their jobs properly.

Amen.

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
