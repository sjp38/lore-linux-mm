From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: NUMA BOF @OLS
Date: Fri, 22 Jun 2007 01:12:51 +0200
Message-ID: <200706220112.51813.arnd@arndb.de>
References: <Pine.LNX.4.64.0706211316150.9220@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751449AbXFUXNL@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0706211316150.9220@schroedinger.engr.sgi.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

On Thursday 21 June 2007, Christoph Lameter wrote:
> If you have another subject that should be brought up then please contact 
> me.

- Interface for preallocating hugetlbfs pages per node instead of system wide

- architecture independent in-kernel API for enumerating CPU sockets with
  multicore processors (not sure if that's the same as your existing subject).

	Arnd <><
