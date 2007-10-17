Date: Wed, 17 Oct 2007 14:50:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memory cgroup enhancements [1/5]  force_empty for
 memory cgroup
Message-Id: <20071017145009.e4a56c0d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.0.9999.0710162232540.27242@chino.kir.corp.google.com>
References: <20071016191949.cd50f12f.kamezawa.hiroyu@jp.fujitsu.com>
	<20071016192341.1c3746df.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.0.9999.0710162113300.13648@chino.kir.corp.google.com>
	<20071017141609.0eb60539.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.0.9999.0710162232540.27242@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 16 Oct 2007 22:38:18 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:
> > Thanks,
> 
> You mean make it write-only?  Typically it would be as easy as only 
> specifying a mode of S_IWUSR so that it can only be written to, the 
> S_IFREG is already provided by cgroup_add_file().
> 
> Unfortunately, cgroups do not appear to allow that.  It hardcodes
> the permissions of 0644 | S_IFREG into the cgroup_create_file() call from 
> cgroup_add_file(), which is a bug.  Cgroup files should be able to be 
> marked as read-only or write-only depending on their semantics.
> 
> So until that bug gets fixed and you're allowed to pass your own file 
> modes to cgroup_add_files(), you'll have to provide the read function.
> 
Hmm. it seems I have to read current cgroup code more.
Thank you for advice.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
