Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [PATCH] (2/2) reverse mappings for current 2.5.23 VM
Date: Wed, 19 Jun 2002 19:46:26 +0200
References: <Pine.LNX.4.44.0206190231520.3637-100000@loke.as.arizona.edu>
In-Reply-To: <Pine.LNX.4.44.0206190231520.3637-100000@loke.as.arizona.edu>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17KjXH-0000vN-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Craig Kulesa <ckulesa@as.arizona.edu>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 19 June 2002 13:21, Craig Kulesa wrote:
> 2.5.22 vanilla:
      ^^--- is this a typo?

> Total kernel swapouts during test = 29068 kB
> Total kernel swapins during test  = 16480 kB
> Elapsed time for test: 141 seconds
> 
> 2.5.23-rmap (this patch -- "rmap-minimal"):           
> Total kernel swapouts during test = 24068 kB
> Total kernel swapins during test  =  6480 kB
> Elapsed time for test: 133 seconds
> 
> 2.5.23-rmap13b (Rik's "rmap-13b complete") :
> Total kernel swapouts during test = 40696 kB
> Total kernel swapins during test  =   380 kB
> Elapsed time for test: 133 seconds

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
