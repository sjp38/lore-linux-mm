Message-Id: <200210030616.g936Gxp01048@Port.imtp.ilyichevsk.odessa.ua>
Content-Type: text/plain;
  charset="us-ascii"
From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Reply-To: vda@port.imtp.ilyichevsk.odessa.ua
Subject: Re: [RFC][PATCH]  4KB stack + irq stack for x86
Date: Thu, 3 Oct 2002 09:10:51 -0200
References: <3D9B62AC.30607@us.ibm.com> <20021002215649.GY3000@clusterfs.com>
In-Reply-To: <20021002215649.GY3000@clusterfs.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Dilger <adilger@clusterfs.com>, Dave Hansen <haveblue@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 2 October 2002 19:56, Andreas Dilger wrote:
> Alternately, you could set up an 8kB stack + IRQ stack and "red-zone"
> the high page of the current 8kB stack and see if it is ever used.

This debugging technique definitely works. Look how many sleeping calls
under locks apkm has caught recently!
--
vda
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
