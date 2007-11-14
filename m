Received: by wa-out-1112.google.com with SMTP id m33so304426wag
        for <linux-mm@kvack.org>; Wed, 14 Nov 2007 09:05:08 -0800 (PST)
Message-ID: <6934efce0711140905h4dff6e70v69598022a3ddad98@mail.gmail.com>
Date: Wed, 14 Nov 2007 09:05:08 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: about page migration on UMA
In-Reply-To: <473A7A0B.5030300@arca.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071016191949.cd50f12f.kamezawa.hiroyu@jp.fujitsu.com>
	 <20071016192341.1c3746df.kamezawa.hiroyu@jp.fujitsu.com>
	 <alpine.DEB.0.9999.0710162113300.13648@chino.kir.corp.google.com>
	 <20071017141609.0eb60539.kamezawa.hiroyu@jp.fujitsu.com>
	 <alpine.DEB.0.9999.0710162232540.27242@chino.kir.corp.google.com>
	 <20071017145009.e4a56c0d.kamezawa.hiroyu@jp.fujitsu.com>
	 <02f001c8108c$a3818760$3708a8c0@arcapub.arca.com>
	 <Pine.LNX.4.64.0710181825520.4272@schroedinger.engr.sgi.com>
	 <6934efce0711091131n1acd2ce1h7bb17f9f3cb0f235@mail.gmail.com>
	 <473A7A0B.5030300@arca.com.cn>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Jacky(GuangXiang Lee)" <gxli@arca.com.cn>
Cc: Christoph Lameter <clameter@sgi.com>, climeter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> what is the way to shut down banks in SDRAM chips?

Well there's partial array self-refresh modes.  However at second
glance that doesn't actually lose data, it just requires a 'wake up'
period to access the partial array.  I had been under the impression
they were lossy modes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
