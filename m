Date: Sat, 21 Sep 2002 18:07:26 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: overcommit stuff
Message-ID: <20335180.1032631645@[10.10.2.3]>
In-Reply-To: <Pine.LNX.4.44.0209220151030.2448-100000@localhost.localdomain>
References: <Pine.LNX.4.44.0209220151030.2448-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@digeo.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> It is intended that you should be able to switch commit modes while
> running.  There is one hole there that we've not got around to
> plugging yet, the handling of MAP_NORESERVE, but otherwise I believe
> it makes sense: please don't take that away.

Not quite sure why you'd want to do that, but if you really do, 
I guess making a config option to disable this stuff is a possibility.

> I like to see those Committed_AS numbers (though I don't care for
> the "_AS" prefix), even though I run loose.

Well, there are cheaper ways of keeping it if it's just a stat for
meminfo ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
