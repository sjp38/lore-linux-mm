From: Daniel Santos <danielfsantos@att.net>
Subject: Please be aware that __always_inline doesn't mean "always inline"!
Date: Wed, 26 Sep 2012 18:20:44 -0500
Message-ID: <50638DCC.5040506@att.net>
Reply-To: Daniel Santos <daniel.santos@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, torvalds@linux-foundation.org
List-Id: linux-mm.kvack.org

I've noticed that there's a lot of misperception about the meaning of
the __always_inline, or more specifically,
__attribute__((always_inline)), which does not actually cause the
function to always be inlined.  Rather, it *allows* gcc to inline the
function, even when compiling without optimizations.  Here is the
description of the attribute from gcc's docs
(http://gcc.gnu.org/onlinedocs/gcc-4.7.2/gcc/Function-Attributes.html)

always_inline
Generally, functions are not inlined unless optimization is specified.
For functions declared inline, this attribute inlines the function even
if no optimization level was specified.

This would even appear to imply that such functions aren't even marked
as "inline" (something I wasn't aware of until today).  The only
mechanism I'm currently aware of to force gcc to inline a function is
the flatten attribute (see https://lkml.org/lkml/2012/9/25/643) which
works backwards, you declare it on the calling function, and it forces
gcc to inline all functions (marked as inline) that it calls.

Daniel
