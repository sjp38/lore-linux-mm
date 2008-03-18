Date: Mon, 17 Mar 2008 22:05:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/8] mm: Add NR_WRITEBACK_TEMP counter
Message-Id: <20080317220514.c8856422.akpm@linux-foundation.org>
In-Reply-To: <20080317191942.482475908@szeredi.hu>
References: <20080317191908.123631326@szeredi.hu>
	<20080317191942.482475908@szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 17 Mar 2008 20:19:10 +0100 Miklos Szeredi <miklos@szeredi.hu> wrote:

> @@ -179,6 +179,7 @@ static int meminfo_read_proc(char *page,
>  		"PageTables:   %8lu kB\n"
>  		"NFS_Unstable: %8lu kB\n"
>  		"Bounce:       %8lu kB\n"
> +		"WritebackTmp: %8lu kB\n"

These fields are documented in Documentation/filesystems/proc.txt (please),
although we're missing some of them now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
