Subject: Re: 2.5.36-mm1
From: Robert Love <rml@tech9.net>
In-Reply-To: <3D8839B5.B37DF31C@digeo.com>
References: <3D8839B5.B37DF31C@digeo.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 19 Sep 2002 04:10:55 -0400
Message-Id: <1032423056.16889.21.camel@phantasy>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2002-09-18 at 04:30, Andrew Morton wrote:

> A reminder that this changes /proc files.  Updated top(1) and
> vmstat(1) source is available at http://surriel.com/procps/

Note to those testing 2.5-mm with the new top(1) and vmstat(1) changes:
I have made RPMs available:

	http://tech9.net/rml/procps/

Besides the VM statistics improvements, there are some other nice
changes from Rik, myself, et al, being merged into the procps package.

	Robert Love


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
