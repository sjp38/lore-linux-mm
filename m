Date: Fri, 30 Jan 2004 12:17:31 -0800
From: Tim Hockin <thockin@sun.com>
Subject: Re: 2.6.2-rc2-mm2
Message-ID: <20040130201731.GY9155@sun.com>
Reply-To: thockin@sun.com
References: <20040130014108.09c964fd.akpm@osdl.org> <1075489136.5995.30.camel@moria.arnor.net> <200401302007.26333.thomas.schlichter@web.de> <1075490624.4272.7.camel@laptop.fenrus.com> <20040130114701.18aec4e8.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040130114701.18aec4e8.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: arjanv@redhat.com, thomas.schlichter@web.de, thoffman@arnor.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 30, 2004 at 11:47:01AM -0800, Andrew Morton wrote:
> > directly calling sys_ANYTHING sounds really wrong to me...

It sounded wrong to me, but it gets done ALL OVER.

> Tim, I do think it would be neater to add another entry point in sys.c for
> nfsd and just do a memcpy.

Do you prefer:

a) make a function
	sys.c: ksetgroups(int gidsetsize, gid_t *grouplist)
   which does the same as sys_setgroups, but without the copy_from_user()
   stuff?  The only user (for now, maybe ever) is nfsd.

b) make a function
	sys.c: nfsd_setgroups(int gidsetsize, gid_t *grouplist)
   which does the same as sys_setgroups, but without the copy_from_user()

c) make the nfsd code build a struct group_info and call
   set_current_groups()

-- 
Tim Hockin
Sun Microsystems, Linux Software Engineering
thockin@sun.com
All opinions are my own, not Sun's
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
