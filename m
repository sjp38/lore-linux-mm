Date: Mon, 15 Sep 2003 16:19:33 +0200
From: Claas Langbehn <claas@rootdir.de>
Subject: Re: 2.6.0-test5-mm2
Message-ID: <20030915141933.GA1246@rootdir.de>
References: <20030914234843.20cea5b3.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030914234843.20cea5b3.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

there is an error, after make modules_install
/lib/modules/2.6.0-test5-mm2/build points to ".",
but it should point to /usr/src/linux-2.6.0-test5-mm5/

bye, claas
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
