From: jbradford@dial.pipex.com
Message-Id: <200210221103.g9MB3dff000792@darkstar.example.net>
Subject: Re: running 2.4.2 kernel under 4MB Ram
Date: Tue, 22 Oct 2002 12:03:39 +0100 (BST)
In-Reply-To: <1035312869.2209.30.camel@amol.in.ishoni.com> from "Amol Kumar Lad" at Oct 22, 2002 02:54:27 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Amol Kumar Lad <amolk@ishoni.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>  I want to run 2.4.2 kernel on my embedded system that has only 4 Mb
> SDRAM . Is it possible ?? Is there any constraint for the minimum SDRAM
> requirement for linux 2.4.2

I've successfully run the following kernels all in 4 MB of RAM:

2.2.13
2.2.20
2.4.18
2.4.19
2.5.40
2.5.41
2.5.43

John.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
