Date: Tue, 25 Nov 2003 00:47:36 -0800
From: Mike Fedyk <mfedyk@matchmail.com>
Subject: Re: OOps! was: 2.6.0-test9-mm5
Message-ID: <20031125084736.GA1357@mis-mike-wstn.matchmail.com>
References: <20031124235807.GA1586@mis-mike-wstn.matchmail.com> <20031125003658.GA1342@mis-mike-wstn.matchmail.com> <Pine.LNX.4.58.0311242013270.1859@montezuma.fsmlabs.com> <20031125051018.GA1331@mis-mike-wstn.matchmail.com> <Pine.LNX.4.58.0311250033170.4230@montezuma.fsmlabs.com> <20031125054709.GC1331@mis-mike-wstn.matchmail.com> <Pine.LNX.4.58.0311250053410.4230@montezuma.fsmlabs.com> <20031125063602.GA1329@mis-mike-wstn.matchmail.com> <20031125075421.GA1342@mis-mike-wstn.matchmail.com> <20031125080512.GA1356@mis-mike-wstn.matchmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20031125080512.GA1356@mis-mike-wstn.matchmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zwane Mwaikambo <zwane@arm.linux.org.uk>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 25, 2003 at 12:05:12AM -0800, Mike Fedyk wrote:
> Trying the last one...

pnp-fix-1

That's the one!  Revert it, and no more oops. :)

00:00.0 Host bridge: VIA Technologies, Inc. VT8377 [KT400 AGP] Host Bridge
00:01.0 PCI bridge: VIA Technologies, Inc. VT8235 PCI Bridge
00:0c.0 Unknown mass storage controller: Promise Technology, Inc. 20269 (rev 02)
00:0e.0 RAID bus controller: CMD Technology Inc PCI0680 (rev 02)
00:0f.0 VGA compatible controller: S3 Inc. 86c325 [ViRGE] (rev 06)
00:10.0 USB Controller: VIA Technologies, Inc. USB (rev 80)
00:10.1 USB Controller: VIA Technologies, Inc. USB (rev 80)
00:10.2 USB Controller: VIA Technologies, Inc. USB (rev 80)
00:10.3 USB Controller: VIA Technologies, Inc. USB 2.0 (rev 82)
00:11.0 ISA bridge: VIA Technologies, Inc. VT8235 ISA Bridge
00:11.1 IDE interface: VIA Technologies, Inc. VT82C586A/B/VT82C686/A/B/VT8233/A/C/VT8235 PIPC Bus Master IDE (rev 06)
00:12.0 Ethernet controller: VIA Technologies, Inc. VT6102 [Rhine-II] (rev 74)

Linux mis-mike-wstn 2.6.0-test9-mm5-revpnp1 #7 SMP Tue Nov 25 00:08:46 PST 2003 i686 GNU/Linux
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
