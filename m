From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: Re: 2.6.26-rc8-mm1: unable to mount nfs shares
Date: Sat, 5 Jul 2008 00:49:33 +0200
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>
In-Reply-To: <20080703020236.adaa51fa.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807050049.33287.m.kozlowski@tuxland.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, kernel-testers@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

$ mount some/nfs/share
mount.nfs: Input/output error

dmesg says: RPC: transport (0) not supported

but I guess it's known issue http://lkml.org/lkml/2008/7/1/438 ?

	Mariusz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
