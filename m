Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: get_free pages!!
Date: Wed, 29 Aug 2001 19:15:11 +0200
References: <OF720BBA27.427D5F18-ON85256AB7.005BD348@storage.com>
In-Reply-To: <OF720BBA27.427D5F18-ON85256AB7.005BD348@storage.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Message-Id: <20010829170832Z16090-32383+2301@humbolt.nl.linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jalajadevi Ganapathy <JGanapathy@storage.com>, Andrew Kay <Andrew.J.Kay@syntegra.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On August 29, 2001 06:44 pm, Jalajadevi Ganapathy wrote:
> How can i get memory pagest greater than order 5.
> If I pass, the value greater than 5 as order, my get_free_pages fails.
> How can i get more than 5 pages!!

You need to supply more information about what your system is doing, how it's 
configured, etc., and please apply the patch from earlier in this thread to 
get better failure messages in your sys messages log.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
