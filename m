Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: get_free pages!!
Date: Wed, 29 Aug 2001 20:02:11 +0200
References: <OFB7807547.807757AE-ON85256AB7.0061862E@storage.com>
In-Reply-To: <OFB7807547.807757AE-ON85256AB7.0061862E@storage.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Message-Id: <20010829175530Z16134-32384+1052@humbolt.nl.linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jalajadevi Ganapathy <JGanapathy@storage.com>, Badari Pulavarty <badari@us.ibm.com>
Cc: Andrew Kay <Andrew.J.Kay@syntegra.com>, linux-mm@kvack.org, Marcelo Tosatti <marcelo@conectiva.com.br>, owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On August 29, 2001 07:46 pm, Jalajadevi Ganapathy wrote:
> Sorry for my hurried question.
> Actually I want to allocate more than MAX_ORDER

Then you want to define MAX_ORDER higher, or you want to use vmalloc.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
