From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 11 Jul 2006 20:29:36 +0200
Message-Id: <20060711182936.31293.58306.sendpatchset@lappy>
Subject: [PATCH 0/2] mm: measuring resource demand
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

This patch set implements a refault histogram. This can be used to
effectively measure resource demand, as outlined in Rik's OLS paper

  "Measuring Resource Demand on Linux"

available at: http://people.redhat.com/~riel/riel-OLS2006.pdf

This current posting is meant to start a discussion on the topic, with
the ultimate goal of getting something like this in mainline.

Peter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
