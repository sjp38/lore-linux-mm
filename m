Date: Mon, 14 Apr 2003 18:03:28 -0700
Subject: Re: 2.5.67-mm3
Message-ID: <20030415010328.GA3299@gnuppy.monkey.org>
References: <20030414015313.4f6333ad.akpm@digeo.com> <20030414110326.GA19003@gnuppy.monkey.org> <200304141707.45601@gandalf>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200304141707.45601@gandalf>
From: Bill Huey (Hui) <billh@gnuppy.monkey.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rudmer van Dijk <rudmer@legolas.dynup.net>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Bill Huey (Hui)" <billh@gnuppy.monkey.org>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 14, 2003 at 05:13:05PM +0200, Rudmer van Dijk wrote:
> this patch fixes it. Maybe it is better to move the call to store_edid up 
> inside the already avilable #ifdef but I'm not sure if that is possible

Now I'm getting console warning "anticipatory scheduler" at boot time
and then having it freeze after mounting root read-only.

bill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
