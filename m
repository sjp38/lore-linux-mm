Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id NAA02436
	for <linux-mm@kvack.org>; Tue, 4 Feb 2003 13:17:30 -0800 (PST)
Date: Tue, 4 Feb 2003 13:12:06 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: hugepage patches
Message-Id: <20030204131206.2b6c33fa.akpm@digeo.com>
In-Reply-To: <m1znpcz0ag.fsf@frodo.biederman.org>
References: <20030131151501.7273a9bf.akpm@digeo.com>
	<20030202025546.2a29db61.akpm@digeo.com>
	<20030202195908.GD29981@holomorphy.com>
	<20030202124943.30ea43b7.akpm@digeo.com>
	<m1n0ld1jvv.fsf@frodo.biederman.org>
	<20030203132929.40f0d9c0.akpm@digeo.com>
	<m1hebk1u8g.fsf@frodo.biederman.org>
	<20030204055012.GD1599@holomorphy.com>
	<m18yww1q5f.fsf@frodo.biederman.org>
	<162820000.1044342992@[10.10.2.4]>
	<m1znpcz0ag.fsf@frodo.biederman.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: mbligh@aracnet.com, wli@holomorphy.com, davem@redhat.com, rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

ebiederm@xmission.com (Eric W. Biederman) wrote:
>
> I can't imagine it being useful to guys like oracle without MAP_SHARED
> support....

MAP_SHARED is supported.  I haven't tested it much though.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
