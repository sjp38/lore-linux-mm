Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id XAA11781
	for <linux-mm@kvack.org>; Thu, 16 Jan 2003 23:03:52 -0800 (PST)
Date: Thu, 16 Jan 2003 23:05:06 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: asm-i386/mmzone.h macro paren/eval fixes
Message-Id: <20030116230506.70fa96f9.akpm@digeo.com>
In-Reply-To: <181070000.1042786246@titus>
References: <20030117063900.GA1036@holomorphy.com>
	<181070000.1042786246@titus>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: wli@holomorphy.com, gone@us.ibm.com, akpm@zip.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
> Ugh. That's why I broke struct page out into a seperate header file.
> OK, Andrew ... now do you believe me? ;-) ;-)

I never disagreed.  But the dependency chain for struct page is pretty long,
too.

The core problem is the practice of putting things which define stuff in the
same header as things which do stuff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
