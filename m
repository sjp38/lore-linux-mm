Subject: Re: 2.5.37-mm1
From: Robert Love <rml@tech9.net>
In-Reply-To: <3D8D5559.AF112E57@digeo.com>
References: <3D8D5559.AF112E57@digeo.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 22 Sep 2002 02:29:11 -0400
Message-Id: <1032676152.967.959.camel@phantasy>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2002-09-22 at 01:30, Andrew Morton wrote:

> Reminder: it breaks top(1) and vmstat(1).  Updates to these tools
> are at http://surriel.com/procps/

FYI, for testers: I have a tarball and RPM available of CVS as of
yesterday, at:

	http://tech9.net/rml/procps/

Rik and I have both been merging some neat code; take a look.

	Robert Love



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
