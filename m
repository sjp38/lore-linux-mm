Message-ID: <390603EA.7DFC64BA@mandrakesoft.com>
Date: Tue, 25 Apr 2000 16:45:30 -0400
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: [patch] memory hog protection
References: <Pine.LNX.4.21.0004240728070.3464-100000@duckman.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Secondly, about the issue you bring up; suppose a database
> server has 75% of memory and with this patch that would be
> reduced to 70% of memory, that's only a very small difference
> to the database server itself, but a BIG difference to the
> dozen or so smaller processes in the system...

...dozen or so smaller processes which are far less important than the
database server :)

-- 
Jeff Garzik              | Nothing cures insomnia like the
Building 1024            | realization that it's time to get up.
MandrakeSoft, Inc.       |        -- random fortune
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
