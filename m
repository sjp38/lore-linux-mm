From: Ruthiano Simioni Munaretti <ruthiano@exatas.unisinos.br>
Subject: Non-contiguous memory allocation
Date: Mon, 20 Oct 2003 14:00:59 -0200
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200310201400.59334.ruthiano@exatas.unisinos.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: sisopiii-l@cscience.org, lmb@exatas.unisinos.br
List-ID: <linux-mm.kvack.org>

Hello folks!

Two months ago, you suggest us an interface implementation in non-contiguous 
memory allocation:

William Lee Irwin III wrote:
> The suggestion was to add an interface to fetch more than one page in
> one call, to reduce various kinds of overheads associated with the round
> trip through the codepaths (dis/re -enabling ints, ticking counters, etc.)

Our question: there are (or --> there was... :) any work in this area? 
Somebody tried to implement this?

Also, do you have any suggestions on how to measure the benefits of this 
approach once it is implemented? For example, which metrics should be used 
and which tools can we use to measure them?

Thanks!
LMB, Ruthiano.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
