From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
Date: Sun, 22 Apr 2001 11:08:33 +0100
Message-ID: <00b5et8fnosiic8ii723qjjnrp4k5ainml@4ax.com>
References: <mibudt848g9vrhaac88qjdpnaut4hajooa@4ax.com> <Pine.LNX.4.30.0104201203280.20939-100000@fs131-224.f-secure.com> <sb72ets3sek2ncsjg08sk5tmj7v9hmt4p7@4ax.com> <3AE1DCA8.A6EF6802@earthlink.net>
In-Reply-To: <3AE1DCA8.A6EF6802@earthlink.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Joseph A. Knapka" <jknapka@earthlink.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 21 Apr 2001 13:16:56 -0600, you wrote:

>"James A. Sutherland" wrote:
>> 
>> Note that process suspension already happens, but with too fine a
>> granularity (the scheduler) - that's what causes the problem. If one
>> process were able to run uninterrupted for, say, a second, it would
>> get useful work done, then you could switch to another. The current
>> scheduling doesn't give enough time for that under thrashing
>> conditions.
>
>This suggests that a very simple approach might be to just increase
>the scheduling granularity as the machine begins to thrash. IOW,
>use the existing scheduler as the "suspension scheduler".

That's effectively what this approach does - the problem is, we need
to prevent this process being scheduled for some significant period of
time. I think just SIGSTOPing each process to be suspended is a more
elegant solution than trying to hack the scheduler to support "Don't
schedule this process for the next 5 seconds", but I'm not certain?


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
