From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: suspend processes at load (was Re: a simple OOM ...) 
Date: Thu, 19 Apr 2001 13:30:05 +0100
Message-ID: <cgmtdt87418vuqc23e2makpq5lf9r345mm@4ax.com>
References: <6m3tdtkpcf22j0pq28is7b7c6digfapg06@4ax.com> <Pine.LNX.4.30.0104191525410.20939-100000@fs131-224.f-secure.com>
In-Reply-To: <Pine.LNX.4.30.0104191525410.20939-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szabolcs Szakacsits <szaka@f-secure.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Apr 2001 15:37:04 +0200 (MET DST), you wrote:

>
>On Thu, 19 Apr 2001, James A. Sutherland wrote:
>> On Wed, 18 Apr 2001 23:11:59 -0300 (BRST), you wrote:
>> >If it sits there in a loop, the rest of the memory that process
>> >uses can be swapped out ;)
>> Also, if your program is busy-waiting for another to complete in that
>> way, you need to feed it into /dev/null and get another program :-)
>
>Is it so difficult to imagine a thread/process, doing its job and
>sometimes checking (changed filestamps, new files in a dir, whatever)
>for new things to do? This is of course a simple, stupid case, real life
>is much more tough (SAP dies on Linux because of its max process limit
>[and forget 2.4]). IMHO you want to stop the river and hope it won't
>flood.

Quite the opposite - I want to drain the river, you want to let it
flood to teach the sysadmin a lesson!


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
