Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: statm_pgd_range() sucks!
Date: Mon, 2 Sep 2002 00:02:38 +0200
References: <20020830015814.GN18114@holomorphy.com> <3D6EDDC0.F9ADC015@zip.com.au>
In-Reply-To: <3D6EDDC0.F9ADC015@zip.com.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17lcnn-0004cP-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>, William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@surriel.com
List-ID: <linux-mm.kvack.org>

On Friday 30 August 2002 04:51, Andrew Morton wrote:
> William Lee Irwin III wrote:
> > (1) shared, lib, text, & total are now reported as what's mapped
> >         instead of what's resident. This actually fixes two bugs:
> 
> hmm.  Personally, I've never believed, or even bothered to try to
> understand what those columns are measuring.  Does anyone actually
> find them useful for anything?  If so, what are they being used for?
> What info do we really, actually want to know?

I don't know what use 'shared' is, but it's clearly not very accurate
since it's just adding up all pages with count >= 1.  The only remotely
correct thing to do here is check for multiple pte reverse pointers.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
