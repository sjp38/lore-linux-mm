Date: Fri, 13 Jun 2003 13:09:03 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Bug in 2.5.70-mm9: df: `/': Value too large for defined data
 type
Message-Id: <20030613130903.600310f0.akpm@digeo.com>
In-Reply-To: <200306131250.51502.schlicht@uni-mannheim.de>
References: <20030613013337.1a6789d9.akpm@digeo.com>
	<200306131250.51502.schlicht@uni-mannheim.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thomas Schlichter <schlicht@uni-mannheim.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thomas Schlichter <schlicht@uni-mannheim.de> wrote:
>
> When I enter 'df' in my bash with -mm9 I get following:
>   Filesystem           1k-blocks      Used Available Use% Mounted on
>   df: `/': Value too large for defined data type

The statfs64 patch isn't doing the right thing with reiserfs.  I shall
fix it.  Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
