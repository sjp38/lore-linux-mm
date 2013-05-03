Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 0A2216B02DA
	for <linux-mm@kvack.org>; Fri,  3 May 2013 11:01:48 -0400 (EDT)
Date: Fri, 3 May 2013 16:01:45 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: PROBLEM: kernel oops on page fault
Message-ID: <20130503150145.GA17260@suse.de>
References: <CAEN0ZYDaHDhNZoJuRn3ZRUCYQyaP4DLwKheh2VFO00bo==0bLg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAEN0ZYDaHDhNZoJuRn3ZRUCYQyaP4DLwKheh2VFO00bo==0bLg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander H <1zeeky@gmail.com>
Cc: linux-mm@kvack.org

On Fri, May 03, 2013 at 11:28:22AM +0200, Alexander H wrote:
> [ 2103.689560] Pid: 7640, comm: cc1plus Not tainted 3.8.11-1-ck #1
> SAMSUNG ELECTRONICS CO., LTD. N150P/N210P/N220P
> /N150P/N210P/N220P

This looks like a vendor kernel of some description. Is it reproducible
with the mainline 3.8.11 kernel?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
