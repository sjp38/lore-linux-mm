Date: Wed, 28 May 2003 12:44:50 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.70-mm1
Message-Id: <20030528124450.4dc532ad.akpm@digeo.com>
In-Reply-To: <3ED4ED6B.2010503@us.ibm.com>
References: <20030527004255.5e32297b.akpm@digeo.com>
	<3ED4ED6B.2010503@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mingming Cao <cmm@us.ibm.com>
Cc: bzzz@tmi.comex.ru, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mingming Cao <cmm@us.ibm.com> wrote:
>
> 
> I have run 50 fsx tests overnight on a 8 way PIII SMP box.  Each fsx 
> test reads/writes on it's own ext3 filesystem.  The 50 filesystems  
> spread over 10 disks.

Thanks for doing that.  I've found a couple of bugs which might explain two
of these.  I'll try the many-fsx test too.  -mm2 should be better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
