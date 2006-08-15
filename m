Date: Tue, 15 Aug 2006 13:25:05 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: mmap maped memory trace
Message-Id: <20060815132505.8184c036.ak@muc.de>
In-Reply-To: <6e88e8570608121443i44991d96y15c4e7ff662f1121@mail.gmail.com>
References: <6e88e8570608121443i44991d96y15c4e7ff662f1121@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikola Gidalov <ngidalov@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 12 Aug 2006 23:43:46 +0200
"Nikola Gidalov" <ngidalov@gmail.com> wrote:

> I'd like to ask you how it is possible to to be notified in the driver
> module whenever the user of driver writes to the mmap-ed memory from
> the driver.

You would need to unmap the area and then on a fault emulate the store instruction
and fake its behaviour.

You probably don't want to go this way, it would be fairly complicated.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
