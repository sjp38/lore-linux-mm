Date: Wed, 10 Sep 2003 11:43:46 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: ide-scsi oops was: 2.6.0-test4-mm3
Message-Id: <20030910114346.025fdb59.akpm@osdl.org>
In-Reply-To: <20030910185537.GB1461@matchmail.com>
References: <20030828235649.61074690.akpm@osdl.org>
	<20030910185338.GA1461@matchmail.com>
	<20030910185537.GB1461@matchmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Fedyk <mfedyk@matchmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mike Fedyk <mfedyk@matchmail.com> wrote:
>
> I have another oops for you with 2.6.0-test4-mm3-1 and ide-scsi. 

ide-scsi is a dead duck.  defunct.  kaput.  Don't use it.  It's only being
kept around for weirdo things like IDE-based tape drives, scanners, etc.

Just use /dev/hdX directly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
