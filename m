Date: Thu, 3 Aug 2000 19:19:06 +1200
From: Chris Wedgwood <cw@f00f.org>
Subject: Re: RFC: design for new VM
Message-ID: <20000803191906.B562@metastasis.f00f.org>
References: <Pine.LNX.4.21.0008021212030.16377-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0008021212030.16377-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Wed, Aug 02, 2000 at 07:08:52PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 02, 2000 at 07:08:52PM -0300, Rik van Riel wrote:

    here is a (rough) draft of the design for the new VM, as
    discussed at UKUUG and OLS. The design is heavily based
    on the FreeBSD VM subsystem - a proven design - with some
    tweaks where we think things can be improved. 

Can the differences between your system and what FreeBSD has be
isolated or contained -- I ask this because the FreeBSD VM works
_very_ well compared to recent linux kernels; if/when the new system
is implement it would nice to know if performance differences are
tuning related or because of 'tweaks'.



  --cw
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
