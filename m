Date: Mon, 14 Apr 2003 18:13:02 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.67-mm3
Message-Id: <20030414181302.0da41360.akpm@digeo.com>
In-Reply-To: <20030415010328.GA3299@gnuppy.monkey.org>
References: <20030414015313.4f6333ad.akpm@digeo.com>
	<20030414110326.GA19003@gnuppy.monkey.org>
	<200304141707.45601@gandalf>
	<20030415010328.GA3299@gnuppy.monkey.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Bill Huey (Hui)" <billh@gnuppy.monkey.org>
Cc: rudmer@legolas.dynup.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Bill Huey (Hui) <billh@gnuppy.monkey.org> wrote:
>
> On Mon, Apr 14, 2003 at 05:13:05PM +0200, Rudmer van Dijk wrote:
> > this patch fixes it. Maybe it is better to move the call to store_edid up 
> > inside the already avilable #ifdef but I'm not sure if that is possible
> 
> Now I'm getting console warning "anticipatory scheduler" at boot time
> and then having it freeze after mounting root read-only.
> 

Could be anything.   Does sysrq not work?

If not, please send me your .config.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
