Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA13896
	for <linux-mm@kvack.org>; Fri, 7 Feb 2003 14:25:15 -0800 (PST)
Date: Fri, 7 Feb 2003 14:24:49 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: hugepage patches
Message-Id: <20030207142449.7b1519d2.akpm@digeo.com>
In-Reply-To: <6315617889C99D4BA7C14687DEC8DB4E023D2E6D@fmsmsx402.fm.intel.com>
References: <6315617889C99D4BA7C14687DEC8DB4E023D2E6D@fmsmsx402.fm.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Seth, Rohit" <rohit.seth@intel.com>
Cc: davem@redhat.com, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Seth, Rohit" <rohit.seth@intel.com> wrote:
>
> The allocated pages will be zapped on the way back from do_mmap_pgoff
> for the failure case.

Bah.  OK.  Why don't we grow i_size in truncate like a real fs?

Ho hum.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
