Date: Wed, 26 Apr 2000 12:43:07 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: pressuring dirty pages (2.3.99-pre6)
Message-ID: <20000426124307.I3792@redhat.com>
References: <m1snwadmcp.fsf@flinx.biederman.org> <Pine.LNX.4.21.0004251642500.10408-100000@duckman.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0004251642500.10408-100000@duckman.conectiva>; from riel@conectiva.com.br on Tue, Apr 25, 2000 at 04:47:52PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: "Eric W. Biederman" <ebiederman@uswest.net>, "Stephen C. Tweedie" <sct@redhat.com>, Mark_H_Johnson.RTS@raytheon.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Apr 25, 2000 at 04:47:52PM -0300, Rik van Riel wrote:
> 
> My current anti-hog code already looks at what the biggest
> process is. Any process which is in the same size class will
> get a special bit set

What clears the bit?

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
